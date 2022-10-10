require('babel-register');
require('babel-polyfill');

module.exports = {
    networks:{
        developement: {
            host: '127.0.0.1:',
            port: '7545',
            network_id: '*' //connect to any network
        },
    },


    contracts_directory: './src/contracts',
    contracts_build_directory: './src/truffle_abis',


    compilers: {
        solc: {
            version: '^0.7.0',
            optimizer: {
                enabled: true,
                runs: 200
            },
        }
    }
}