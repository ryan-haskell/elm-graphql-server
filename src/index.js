const fs = require("fs")
const path = require("path")
const { Elm } = require("../dist/elm.worker")
const { ApolloServer } = require("apollo-server")
const {
  ApolloServerPluginLandingPageGraphQLPlayground,
} = require("apollo-server-core")

const typeDefs = fs.readFileSync(path.join(__dirname, "schema.gql"), {
  encoding: "utf8",
})
let worker = Elm.Worker.init()

const resolvers = {
  Query: {
    hello: () => {
      return new Promise((resolve, reject) => {
        let port = worker?.ports?.outgoing

        if (port) {
          port.subscribe(resolve)
        } else {
          reject(Error("Elm ain't right"))
        }
      })
    },
  },
}

const start = async () => {
  const server = new ApolloServer({
    typeDefs,
    resolvers,
    plugins: [ApolloServerPluginLandingPageGraphQLPlayground()],
  })
  const { url } = await server.listen()

  console.log(`🤘 Backend ready at ${url}`)
}

start()
