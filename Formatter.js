const fs = require('fs')
const path = require('path')
const sleep = ms => new Promise(r => setTimeout(r, ms));


const getAllFiles = function(dirPath, arrayOfFiles) {
  let files = fs.readdirSync(dirPath)

  arrayOfFiles = arrayOfFiles || []

  files.forEach(function(file) {
    if (fs.statSync(dirPath + "/" + file).isDirectory()) {
      arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles)
    } else {
      arrayOfFiles.push(path.join(__dirname, dirPath, "/", file))
    }
  })

  return arrayOfFiles
}

async function replaceFile(file_path) {
    fs.readFile(file_path, (err, data) => {
        if (err) throw err;

        let new_data = "";

        for (let i = 0; i < data.length; i++) {
            // 0x0D, 0x0D, 0x0A
            // CR,   CR,   LF
            if (data[i] == 0x0D && data[i + 1] == 0x0D && data[i + 2] == 0x0A) {
                // Found CRCRLF, Replace it with just LF and advance the array
                i += 2; // Skip the next 2 bytes
                new_data += String.fromCharCode(0x0A); // Switch to just LF, no CR
                continue
            }
            new_data += String.fromCharCode(data[i]);
        }
        fs.writeFile(file_path, new_data, () => {})
    })
}

let files = getAllFiles('.')
for (let i = 0; i < files.length; i++) {
    let good_extensions = ['.nut', '.gnut', '.txt', '.cfg', '.res', '.menu']
    let file_extension = path.extname(files[i])
    if (good_extensions.includes(file_extension)) {
        replaceFile(files[i])
    } else {
        console.log(files[i], 'skipped')
    }
}
