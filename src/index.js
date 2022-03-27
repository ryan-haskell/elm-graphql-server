const fs = require("fs")
const path = require("path")
const { ApolloServer } = require("apollo-server")
const { ApolloServerPluginLandingPageGraphQLPlayground } = require("apollo-server-core")

// This project requires sqlite version 3.35.0,
// so we cannot use the standard `sqlite3` NPM package (it's still on 3.34.0)
const sqlite3 = require('@louislam/sqlite3')
const { open } = require('sqlite')
const { nextTick } = require("process")

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
        const before = await db.get(`SELECT count(*) as count FROM migrations`)
        migrationsBefore = before.count
      } catch {}
      await db.migrate()
      const { count: migrationsAfter } = await db.get(`SELECT count(*) as count FROM migrations`)

      const newMigrationsRun = migrationsAfter - migrationsBefore
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
  const warn = console.warn
  console.warn = () => undefined
  const value = fn()
  console.warn = warn
  return value
}
const { Elm } = silent(() => require("../dist/elm.worker"))

// Import GraphQL schema from file
const typeDefs = fs.readFileSync(
  path.join(__dirname, "schema.gql"),
  { encoding: "utf8" }
)


// GraphQL resolvers are dynamically generated
const fieldHandler = (objectName) => ({
  get (_, fieldName) {
    if (fieldName === "__isTypeOf") return () => objectName
    return (parent, args, context, info) => {
      // console.log(info.path)
      const request = { objectName, fieldName, parent, args, context, info }

      context.worker.ports.runResolver.send({ request })
      
      return new Promise((resolve, reject) => {
        const handlers = {
          SUCCESS: (value) => resolve(value),
          FAILURE: (reason) => reject(Error(reason)),
          DATABASE_OUT: async (sql) => {
            console.log(`\n\n💾 ${sql}\n`)
            let response = await context.db.all(sql)
            console.table(response)
    
            context.worker.ports.databaseIn.send({ request, response })
          },
          BATCH_OUT: async ({ id, pathId }) => {
            if (context.batchRequestIds[pathId] === undefined) {
              context.batchRequestIds[pathId] = []

              setTimeout(() => {
                console.log('Sending batch IDs for: ', context.batchRequestIds[pathId])

                context.worker.ports.batchIn.send({
                  request,
                  pathId,
                  ids: context.batchRequestIds[pathId]
                })
              }, 300) // TODO: Find a smarter way to handle this
            }

            context.batchRequestIds[pathId].push(id)

            console.log(context.batchRequestIds[pathId])
            
          }
        }

        context.worker.ports.outgoing.subscribe(msg => {
          // This conditional is critical for our resolver to work,
          // because it ignores any Elm messages from other resolvers
          // 
          // WARNING: JS uses object references for equality. If anything
          // freaky starts to happen– we should change this code to use
          // something like an Integer ID, rather than comparing the full
          // JSON request objects.
          if (msg.request === request) {
            const handler = handlers[msg.tag]
            if (handler) {
              handler(msg.payload)
            } else {
              console.warn(`❗️ Unrecognized port tag: ${msg.tag}`)
            }
          }
        })
      })
    }
  },
})

// The function to run when the server starts up
const start = async () => {
  // Start up sqlite database
  const db = await Database.start()

  // Start GraphQL server
  const server = new ApolloServer({
    typeDefs,
    resolvers: new Proxy({}, {
      get(_, objectName) {
        return new Proxy({}, fieldHandler(objectName))
      }
    }),
    context: ({ req }) => ({
      // Each GraphQL request gets it's own Elm program
      worker: Elm.Main.init(),
      // Allows us to prevent the N+1 problem, and batch similar requests
      batchRequestIds: {},
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
