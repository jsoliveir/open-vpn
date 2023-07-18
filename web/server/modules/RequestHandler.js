export default class RequestHandler {
  constructor(req, res) {
    this.req = req
    this.res = res
  }
  async invoke(func) {
    const log = [
      new Date().toJSON(),
      "Host:", this.req.headers.host,
      "Path:", this.req.path,
      "User Agent:", this.req.headers["user-agent"],
    ]
    try {
      console.log(log.join(" "))
      const result = await func(log)
      if (typeof result === "string")
        this.res.end(result)
      else
        this.res.end(JSON.stringify(result))
    } catch (err) {

      if (typeof err === "number") {
        this.res.status(err)
      }
      else {
        this.res.status(500)
      }
      
      log.push(JSON.stringify(err))
      log.push(err.stack)
      console.error(log.join(" "))
    } finally {
      this.res.end()
    }
  }
}