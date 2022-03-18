const silent = (fn) => {
  // Temporarily mute console.warn
  // to hide "Elm in DEV MODE" message
  let warn = console.warn
  console.warn = () => undefined
  let value = fn()
  console.warn = warn
  return value
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
  get(target, fieldName, receiver) {
    if (fieldName === "__isTypeOf") return () => objectName
    return (parent, args) => {
      let worker = Elm.Worker.init({
        flags: { objectName, fieldName, parent, args },
      })

      return new Promise((resolve, reject) => {
        worker.ports.success.subscribe(resolve)
        worker.ports.failure.subscribe((json) => reject(Error(json)))
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
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [ApolloServerPluginLandingPageGraphQLPlayground()],
  })
  const { url } = await server.listen()

  console.log(`GraphQL API ready at ${url}`)
}

start()
