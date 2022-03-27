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

const toUniqueResolverId = (path) => {
  let key = typeof path.key === 'string' ? path.key : `[${path.key}]`
  if (path.prev) {
    return toUniqueResolverId(path.prev) + "." + key
  } else {
    return key
  }
}

// GraphQL resolvers are dynamically generated
const fieldHandler = (objectName) => ({
  get (_, fieldName) {
    if (fieldName === "__isTypeOf") return () => objectName
    return (parent, args, context, info) => {
      const resolverId = toUniqueResolverId(info.path)

      context.worker.ports.runResolver.send({ resolverId, request: { objectName, fieldName, parent, args, context, info } })

      return new Promise((resolve, reject) => {
        const handlers = {
          SUCCESS: (value) => {
            resolve(value)
          },
          FAILURE: (reason) => reject(Error(reason)),
          DATABASE_OUT: async ({ sql, batchId }) => {
            const key = batchId + sql
            const sendToElm = (response) => context.worker.ports.databaseIn.send({ resolverId, response })

            if (context.sqlCache[key]) {
              const cachedResponse = context.sqlCache[key].response
              console.log('✅ Cache hit')
              if (cachedResponse) {
                // If this SQL statement has already run, return the cached result
                sendToElm(cachedResponse)
              } else {
                // If this SQL statement is currently being run, add yourself to
                // the list of resolvers needing the data.
                context.sqlCache[key].subscribers.push(sendToElm)
              }
            } else {
              // If you're the first one here, run the SQL query!
              context.sqlCache[key] = { subscribers: [], response: undefined }

              console.log(`\n\n💾 ${sql}\n`)
              let response = await context.db.all(sql)
              console.table(response)

              sendToElm(response)

              // Let everyone else know
              context.sqlCache[key].response = response
              context.sqlCache[key].subscribers.forEach(otherResolversNeedingData => {
                otherResolversNeedingData(response)
              })
            }
          },
          BATCH_OUT: async ({ id, batchId }) => {
            if (context.batchRequestIds[batchId] === undefined) {
              context.batchRequestIds[batchId] = []

              setTimeout(() => {
                // console.log('Sending batch IDs for: ', context.batchRequestIds[batchId])

                context.worker.ports.batchIn.send({
                  resolverId,
                  batchId,
                  ids: context.batchRequestIds[batchId]
                })
              }) // TODO: Find a smarter way to handle this
            }

            context.batchRequestIds[batchId].push(id)

            // console.log(context.batchRequestIds[batchId])
            
          }
        }

        context.worker.ports.outgoing.subscribe(msg => {
          // This conditional is critical for our resolver to work,
          // because it ignores any Elm messages from other resolvers
          // console.log(msg.tag, msg.resolverId)
          if (msg.resolverId === resolverId) {
            const handler = handlers[msg.tag]
            if (handler) {
              handler(msg.payload)
            } else {
              console.warn(`❗️ Unrecognized port tag: ${msg.tag}`)
            }
          } else {
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
      // Allows us to guarantee batched SQL statements only execute once
      sqlCache: {},
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
