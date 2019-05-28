const express = require("express");
const app = express();
const { resolve } = require("path");
const { inspect } = require("util");
const { spawn } = require("child_process");

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
    const ls = spawn("make", ["verify"], {
      cwd: resolve(process.cwd(), "../")
    });
    ls.stdout.on("data", data => {
      console.log(`stdout: ${data}`);
    });

    ls.stderr.on("data", data => {
      console.log(`stderr: ${data}`);
    });

    ls.on("exit", code => {
      console.log(`child process exited with code ${code}`);
      res.sendStatus(200);
    });
  });

app.listen(3001);
