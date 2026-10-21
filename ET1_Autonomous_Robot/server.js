/*
----------------------------------------------------------
ET1 Autonomous Mobile Robot

File: server.js
Language: JavaScript (Node.js)

Description:
This server provides a web interface for controlling the
robot using Socket.IO. It listens for commands from the
HTML page and executes the corresponding Python scripts
that control the Raspberry Pi robot.

The original project report incorrectly labels this file
as "Python". This implementation is actually JavaScript
running on Node.js.
----------------------------------------------------------
*/

const express = require("express");
const { exec } = require("child_process");
const http = require("http");
const { Server } = require("socket.io");

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static("public"));

io.on("connection", (socket) => {
    console.log("Client connected.");

    socket.on("moveForward", (state) => {
        if (state) {
            exec("python3 forward.py", (error, stdout, stderr) => {
                if (error) {
                    socket.emit("status", `Forward movement error: ${error.message}`);
                    socket.emit("moveForward", false);
                    return;
                }

                if (stderr) {
                    socket.emit("status", stderr);
                }

                socket.emit("status", stdout);
                socket.emit("moveForward", false);
            });
        }
    });

    socket.on("moveBackward", (state) => {
        if (state) {
            exec("python3 backward.py", (error, stdout, stderr) => {
                if (error) {
                    socket.emit("status", `Backward movement error: ${error.message}`);
                    socket.emit("moveBackward", false);
                    return;
                }

                if (stderr) {
                    socket.emit("status", stderr);
                }

                socket.emit("status", stdout);
                socket.emit("moveBackward", false);
            });
        }
    });

    socket.on("randomMovement", (state) => {
        if (!state) {
            return;
        }

        const interval = setInterval(() => {
            exec("python3 forward.py", (forwardError, forwardOutput) => {
                if (forwardError) {
                    socket.emit(
                        "status",
                        `Forward movement error: ${forwardError.message}`
                    );
                    return;
                }

                socket.emit("status", forwardOutput);

                exec("python3 backward.py", (backwardError, backwardOutput) => {
                    if (backwardError) {
                        socket.emit(
                            "status",
                            `Backward movement error: ${backwardError.message}`
                        );
                        return;
                    }

                    socket.emit("status", backwardOutput);
                });
            });
        }, 5000);

        socket.once("randomMovement", (newState) => {
            if (!newState) {
                clearInterval(interval);
                socket.emit("status", "Random movement stopped.");
            }
        });
    });

    socket.on("disconnect", () => {
        console.log("Client disconnected.");
    });
});

server.listen(8080, () => {
    console.log("Server running on http://localhost:8080");
});
