const silent = (fn) => {
  // Temporarily mute console.warn
  // to hide "Elm in DEV MODE" message
  let warn = console.warn
  console.warn = () => undefined
  let value = fn()
  console.warn = warn
  return value
}

const Database = {
  start: async () => {
    // This project requires sqlite version 3.35.0,
    // so we cannot use the standard `sqlite3` NPM package (it's still on 3.34.0)
    const sqlite3 = require('@louislam/sqlite3')
    const { open } = require('sqlite')

    // Open the database
    db = await open({
      filename: './database.db',
      driver: sqlite3.Database
    })

    // CREATE TABLES
    await db.exec(`
      CREATE TABLE IF NOT EXISTS people (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT
      )
    `)
    
    const result = await db.all('SELECT id FROM people LIMIT 1')
    if (result.length === 0) {
      console.log('💾 Empty database detected, initializing!')
      await db.exec(`
          INSERT INTO people ( name, email ) VALUES
            ( "Ryan" , "ryan@elm.land" ),
            ( "Duncan" , "duncan@elm.land" ),
            ( "Scott" , "scott@elm.land" )
      `)
    } else {
      console.log('💾 SQL database ready!')
    }
    
    return db
  }
}


const fs = require("fs")
const path = require("path")
const { Elm } = silent(() => require("../dist/elm.worker"))

const { ApolloServer } = require("apollo-server")
const {
  ApolloServerPluginLandingPageGraphQLPlayground,
} = require("apollo-server-core")

const typeDefs = fs.readFileSync(path.join(__dirname, "schema.gql"), {
  encoding: "utf8",
})

const fieldHandler = (objectName) => ({
  get (target, fieldName, receiver) {
    if (fieldName === "__isTypeOf") return () => objectName
    return (parent, args, context) => {
      let worker = Elm.Worker.init({
        flags: { objectName, fieldName, parent, args },
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

const resolvers = new Proxy(
  {},
  {
    get(target, objectName, receiver) {
      return new Proxy({}, fieldHandler(objectName))
    },
  }
)

const start = async () => {
  // Start up sqlite database
  let db = await Database.start()

  // Start GraphQL server
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    context: { db },
    plugins: [ApolloServerPluginLandingPageGraphQLPlayground()],
  })


  const { url } = await server.listen()

  console.log(`✨ GraphQL API ready at ${url}`)
}

start()
