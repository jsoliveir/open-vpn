#!/usr/local/bin/node
const process = require("process")
const fs = require("fs")

const username = process.env.username
const password = process.env.password 

const data = fs.readFileSync(`${__dirname}/database.json`, 'utf8');
const database = JSON.parse(data)

const authorized = 
  database[username] && database[username] == password

if(!authorized){
  console.log(new Date().toJSON(),`[${username}]`,"invalid username or password")
  process.exit(1)
}