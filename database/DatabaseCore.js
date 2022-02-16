const DB = require('../storage/dbconn');

/**
 * @param tableName
 * @param parameterWhere
 * @param parameterColumns - Optional array with column names to get
 * @param parameterOrderBy - Map with column ASC/DESC name and value
 * @returns {Promise<any>}
 */
async function select(tableName, parameterWhere, parameterColumns = null, parameterOrderBy = null) {
    const arrParameterized = [];
    let query = `SELECT `;
    if (parameterColumns) {
        query += parameterColumns.join(', ');
        query += ` FROM ${tableName} WHERE `;
    } else {
        query += `* FROM ${tableName} WHERE`;
    }
    //WHERE
    for (const [key, value] of parameterWhere.entries()) {
        query += ` ${key} = ? AND `;
        arrParameterized.push(value);
    }
    query = query.replace(/AND\s*$/, "");//remove the last AND and any whitespace
    query += " LIMIT 1";

    return await DB.conn.query(query, arrParameterized);
}

/*
*@param parameterColumns - Optional array with column names to get
@param parameterOrderBy - Map with column ASC/DESC name and value
 */
async function selectAll(tableName, parameterWhere = null, parameterOrderBy = null, parameterColumns = null) {
    let arrParameterized = [];

    let query = `SELECT `;
    if (parameterColumns) {
        query += parameterColumns.join(', ');
        query += ` FROM ${tableName}`;
    } else {
        query += `* FROM ${tableName}`;
    }

    if (parameterWhere != null) {
        query += " WHERE ";
        //WHERE
        for (const [key, value] of parameterWhere.entries()) {
            query += ` ${key} = ? AND `;
            arrParameterized.push(value);
        }
        query = query.replace(/AND\s*$/, "");//remove the last AND and any whitespace
    }

    if (parameterOrderBy != null) {
        query += " ORDER BY ";
        for (const [key, value] of parameterOrderBy.entries()) {
            query += ` ${key} ${value}, `;
        }
    }
    query = query.replace(/,\s*$/, "");//remove the last comma and any whitespace

    return await DB.conn.query(query, arrParameterized);
}

/**
 * Select 1 random row
 * @param tableName
 * @param parameterWhere
 * @param totalRandom
 * @returns {Promise<any>}
 */
async function selectRandom(tableName, parameterWhere = null, totalRandom = 1) {
    let arrParameterized = [];
    let query = `SELECT *
                 FROM ${tableName} `;

    if (parameterWhere != null) {
        query += " WHERE ";
        //WHERE
        for (const [key, value] of parameterWhere.entries()) {
            query += ` ${key}=? AND `;
            arrParameterized.push(value);
        }
        query = query.replace(/AND\s*$/, "");//remove the last AND and any whitespace

    }

    query += ` ORDER BY RAND() LIMIT ${totalRandom}`;

    return await DB.conn.query(query, arrParameterized);
}

/**
 * Select 1 random row, no duplicates
 * @param tableName
 * @param parameterWhere
 * @param parameterGroupBy
 * @param totalRandom
 * @returns {Promise<any>}
 */
async function selectRandomNonDuplicate(tableName, parameterWhere = null,
                                        parameterGroupBy = null, totalRandom = 1) {
    let arrParameterized = [];
    let query = `SELECT *
                 FROM ${tableName} `;

    if (parameterWhere != null) {
        query += " WHERE ";
        //WHERE
        for (const [key, value] of parameterWhere.entries()) {
            query += ` ${key}=? AND `;
            arrParameterized.push(value);
        }
        query = query.replace(/AND\s*$/, "");//remove the last AND and any whitespace
    }

    query += ` GROUP BY ${parameterGroupBy} ORDER BY RAND() LIMIT ${totalRandom}`;

    return await DB.conn.query(query, arrParameterized);
}

/**
 * Insert something into a table
 * @param tableName
 * @param parameter
 * @returns {Promise<any>}
 */
async function insert(tableName, parameter) {
    let arrParameterized = [];
    let query = `INSERT INTO ${tableName} `;
    query += `(`;
    for (const [key, value] of parameter.entries()) {
        query += `${key},`;
        arrParameterized.push(value);
    }
    query = query.replace(/,\s*$/, "");//remove last comma and any whitespace
    query += `) VALUES(`;
    arrParameterized.forEach(() => {
        query += `?,`;
    });
    query = query.replace(/,\s*$/, "");//remove last comma and any whitespace
    query += `)`;
    return await DB.conn.query(query, arrParameterized);
    // DB.conn.query(
    //      query,arrParameterized,
    //     function (err) {}
    // );
}

/**
 * Insert multiple rows into a table
 * @param tableName
 * @param parameter
 * @returns {Promise<any>}
 */
async function insertMultiple(tableName, parameter) {
    //parameter in array[] that contains multiple map:
    //e.g: [
    // Map(2) { 'id_card' => 'akhi501' },
    // Map(2) { 'id_card' => 'mami201' }
    // ]
    let arrParameterized = [];
    let query = `INSERT INTO ${tableName} `;
    query += `(`;
    for (const [key, value] of parameter[0].entries()) {
        query += `${key},`;
    }
    query = query.replace(/,\s*$/, "");//remove last comma and any whitespace
    query += `) VALUES`;

    for (let i = 0; i < parameter.length; i++) {
        query += `(`;
        for (const [key, value] of parameter[i].entries()) {
            arrParameterized.push(value);
            query += `?,`;
        }
        query = query.replace(/,\s*$/, "");//remove last comma and any whitespace
        query += `),`;
    }
    query = query.replace(/,\s*$/, "");//remove last comma and any whitespace

    return await DB.conn.query(query, arrParameterized);
}

/**
 * Update a table
 * @param tableName
 * @param parameterSet
 * @param parameterWhere
 * @returns {Promise<any>}
 */
async function update(tableName, parameterSet, parameterWhere) {
    let arrParameterized = [];
    let query = `UPDATE ${tableName}
                 SET `;
    //SET
    for (const [key, value] of parameterSet.entries()) {
        query += ` ${key} = ?,`;
        arrParameterized.push(value);
    }
    query = query.replace(/,\s*$/, "");//remove the last comma and any whitespace
    //WHERE
    query += " WHERE ";
    for (const [key, value] of parameterWhere.entries()) {
        query += ` ${key} = ? AND `;
        arrParameterized.push(value);
    }
    query = query.replace(/AND\s*$/, "");//remove the last comma and any whitespace
    // DB.conn.query(query,arrParameterized,function (err) {});
    return await DB.conn.query(query, arrParameterized);
}

/**
 * Delete something from a table
 * @param tableName
 * @param parameterWhere
 * @returns {Promise<any>}
 */
async function del(tableName, parameterWhere) {
    //delete
    let arrParameterized = [];
    let query = `DELETE
                 FROM ${tableName} `;
    //WHERE
    query += " WHERE ";
    for (const [key, value] of parameterWhere.entries()) {
        query += ` ${key}=? AND `;
        arrParameterized.push(value);
    }
    query = query.replace(/AND\s*$/, "");//remove the last comma and any whitespace
    // DB.conn.query(query,arrParameterized,function (err) {});
    return await DB.conn.query(query, arrParameterized);
}

/**
 * Count rows in a table
 * @param tableName
 * @param parameterWhere
 * @returns {Promise<any>}
 */
async function count(tableName, parameterWhere = null) {
    //simple count
    let arrParameterized = [];
    let query = `SELECT COUNT(*) as total
                 FROM ${tableName} `;
    if (parameterWhere != null) {
        //WHERE
        query += " WHERE ";
        for (const [key, value] of parameterWhere.entries()) {
            query += ` ${key}=? AND `;
            arrParameterized.push(value);
        }
        query = query.replace(/AND\s*$/, "");//remove the last comma and any whitespace
    }

    // DB.conn.query(query,arrParameterized,function (err) {});
    return await DB.conn.query(query, arrParameterized);
}

module.exports = {
    DB,
    select,
    selectRandom,
    selectRandomNonDuplicate,
    selectAll,
    insert,
    insertMultiple,
    update,
    del,
    count
};
