const fs = require("fs")
const path = require("path")
const { ApolloServer } = require("apollo-server")
const { ApolloServerPluginLandingPageGraphQLPlayground } = require("apollo-server-core")

// This project requires sqlite version 3.35.0,
// so we cannot use the standard `sqlite3` NPM package (it's still on 3.34.0)
const sqlite3 = require('@louislam/sqlite3')
const { open } = require('sqlite')

const Database = {
  start: async () => {
    // Open a database connection
    db = await open({
      filename: './database.db',
      driver: sqlite3.Database
    })

    // Run SQL migrations if in development
    if (process.env.NODE_ENV !== 'production') {
      console.log(`💾 Making sure SQL database is up-to-date...`)
      let migrationsBefore = 0
      try {
        let before = await db.get(`SELECT count(*) as count FROM migrations`)
        migrationsBefore = before.count
      } catch {}
      await db.migrate()
      let { count: migrationsAfter } = await db.get(`SELECT count(*) as count FROM migrations`)

      let newMigrationsRun = migrationsAfter - migrationsBefore
      if (newMigrationsRun === 1) {
        console.info(`💾 Ran ${newMigrationsRun} migration!`)
      } else if (newMigrationsRun > 1) {
        console.info(`💾 Ran ${newMigrationsRun} migrations!`)
      }
    }

    return db
  }
}

// Silent temporarily mutes console.warn
// to hide Elm's "DEV MODE" warnings on import
const silent = (fn) => {
  let warn = console.warn
  console.warn = () => undefined
  let value = fn()
  console.warn = warn
  return value
}
const { Elm } = silent(() => require("../dist/elm.worker"))

// Import schema.gql
const typeDefs = fs.readFileSync(path.join(__dirname, "schema.gql"), {
  encoding: "utf8",
})

// Define dynamic resolvers, using a JS object proxy
const fieldHandler = (objectName) => ({
  get (target, fieldName, receiver) {
    if (fieldName === "__isTypeOf") return () => objectName
    return (parent, args, context, info) => {
      // console.log({ currentUserId: context.currentUserId })
      let worker = Elm.Main.init({
        flags: { objectName, fieldName, parent, args, context },
      })

      return new Promise((resolve, reject) => {
        worker.ports.success.subscribe(resolve)
        worker.ports.failure.subscribe((json) => reject(Error(json)))
        worker.ports.databaseOut.subscribe(async ({ id, sql }) => {
          console.log(`\n\n💾 ${sql}\n`)
          let response = await context.db.all(sql)
          console.table(response)

          worker.ports.databaseIn.send({ id, response })
        })
      })
    }
  },
})

const resolvers = new Proxy({}, {
  get(target, objectName, receiver) {
    return new Proxy({}, fieldHandler(objectName))
  }
})

// The function to run when the server starts up
const start = async () => {
  // Start up sqlite database
  let db = await Database.start()

  // Start GraphQL server
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: ({ req }) => ({
      currentUserId: req.header('Authorization'),
      db
    }),
    plugins: [ApolloServerPluginLandingPageGraphQLPlayground()],
  })

  const { url } = await server.listen()

  console.log(`✨ GraphQL API ready at ${url}`)
}

// Start the server!
start()
