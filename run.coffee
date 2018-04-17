console.log '===================='
glob=require 'glob'
glob 'src/pages/user/*.coffee',{},(er,files)=>
    console.log files
    console.log '----------'