const express = require("express");
const app = express();
const { inspect } = require("util");

app
  .use(express.json())
  .use(express.urlencoded({ extended: false }))
  .post("/target", function(req, res) {
    console.log(
      `Hey ${req.body.consumerName} contract has changed\n${inspect(req.body, {
        showHidden: true,
        depth: null
      })}`
    );
    res.sendStatus(200);
  });

app.listen(3001);
