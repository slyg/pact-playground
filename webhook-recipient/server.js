const express = require("express");
const app = express();

app.post("/target", function(req, res) {
  console.log("Hey");
  res.sendStatus(200);
});

app.listen(3001);
