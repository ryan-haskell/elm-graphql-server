# @ryannhg/elm-graphql-server
> Create a GraphQL API with Elm!

![A screenshot of a demo query in the GraphQL playground](./screenshot.png)

### Playing around locally

_You'll need [Node.js](https://nodejs.org) to run this project on your local computer._

```bash
npm start
```

- Visit http://localhost:4000 to use the GraphQL API
- Mess with Elm files in `src/Resolvers` to change how the API responds

### Overview

The server starts in a file called `src/index.js`. It is powered by an Elm program, compiled
as a `Platform.worker`. That means you'll need to compile your Elm app first with `npm run elm:build`, or you can use the `npm run dev` script that automatically compiles things as you code!

Right now, the API server doesn't do too much. It listens for GraphQL requests at `http://localhost:4000`, and sends that request information to our Elm worker, so we can handle our resolvers with Elm code.

For now, you can modify the GraphQL schema by editing `src/schema.gql`, and add a new resolver in `src/Worker.elm`.

I have been making modules in `src/Resolvers` to organize the code, but that's just so you can easily follow what's going on!

This is not a production-ready thing, but I thought it would be a fun experiment to see what using the Elm language would be like for a backend GraphQL API.

A real implementation would require a nice way to talk to a database, a third-party HTTP service, or do things like application logging– but for now this is all we have 🙂

#### Talking to a SQL Database

I've been exploring communicating to a `sqlite` database. This project supports basic forms of:

- [x] `SELECT` statements
  - Example of `findOne` with the [`person` query](./src/Resolvers/Query/Person.elm)
  - Example of `findAll` with the [`people` query](./src/Resolvers/Query/People.elm)
- [x] `INSERT` statements
  - Example of `insertOne` with the [`createPerson` mutation](./src/Resolvers/Mutation/CreatePerson.elm)
- [x] `UPDATE` statements
  - Example of `updateOne` with the [`updatePerson` mutation](./src/Resolvers/Mutation/UpdatePerson.elm)
- [x] `DELETE` statements
  - Example of `deleteOne` with the [`deletePerson` mutation](./src/Resolvers/Mutation/DeletePerson.elm)