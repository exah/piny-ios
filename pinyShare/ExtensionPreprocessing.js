var ExtensionPreprocessingJS = {
  async run({ completionFunction }) {
    completionFunction({
      url: document.location.href,
      title: document.title
    })
  }
}
