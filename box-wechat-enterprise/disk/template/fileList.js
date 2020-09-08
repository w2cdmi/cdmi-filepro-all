// const fileList = {
//   show() {

//   }
// };

class FileList {
  constructor(params) {
    this.data = params || {}
  }
  showsharelist() {
    console.log("haha")
  }
  checked_item(params) {
    console.log("xxxx", params)

  }
}
module.exports = {
  FileList
};