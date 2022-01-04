// Used for testing

const crypto = require("crypto")

const ALGORITHM = 'aes-256-gcm'

const encrypt = (keyBuffer, dataBuffer) => {
  // iv stands for "initialization vector"
  const iv = crypto.randomBytes(12)
  const cipher = crypto.createCipheriv(ALGORITHM, keyBuffer, iv)
  const encryptedBuffer = Buffer.concat([cipher.update(dataBuffer), cipher.final()])
  const authTag = cipher.getAuthTag()
  let bufferLength = Buffer.alloc(1)
  bufferLength.writeUInt8(iv.length, 0)
  return Buffer.concat([bufferLength, iv, authTag, encryptedBuffer])
}

const decrypt = (keyBuffer, dataBuffer) => {
  const ivSize = dataBuffer.readUInt8(0)
  const iv = dataBuffer.slice(1, ivSize + 1)
  // The authTag is by default 16 bytes in AES-GCM
  const authTag = dataBuffer.slice(ivSize + 1, ivSize + 17)
  const decipher = crypto.createDecipheriv(ALGORITHM, keyBuffer, iv)
  decipher.setAuthTag(authTag)
  const cipherText = dataBuffer.slice(ivSize + 17)
  return Buffer.concat([decipher.update(cipherText), decipher.final()])
}

let key = "bc5969766cb411ec90d60242ac120003"
let content = JSON.stringify({
    from: "fX5xxL7Ctknps3d-jb70_F:APA91bGbYiEkCy2MzMwlXf-k_O2lElLZVy5-MPZN9HIpQZxgCHAHgA16IOJPL66yWIPn3qIjpNfvxein2XuqG07rSBreOWNEgTZXSfkerds0QWcrjwFjBmdOv8t3WjFJw11ont-kLFeb",
    name: "Mille",
    content: "hello bozo",
    time: "2012-04-23T18:25:43.511Z"
})
let encrypted = encrypt(Buffer.from(key), Buffer.from(content))
console.log(encrypted.toString('base64'));
// let decrypted = decrypt(Buffer.from(key), encrypted)
// console.log(decrypted.toString());
