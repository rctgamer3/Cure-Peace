const DB = require('mariadb');
require('dotenv').config({path: 'storage/config/sql.env'});
const conn = DB.createPool({
    host: process.env.SQL_HOST,
    port: parseInt(process.env.SQL_PORT),
    user: process.env.SQL_USER,
    password: process.env.SQL_PASS,
    database: process.env.SQL_DB
});

module.exports = {conn};