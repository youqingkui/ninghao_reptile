request = require('request')
async   = require("async")
fs      = require("fs")
cheerio = require('cheerio')

class NingHao
  constructor:(@courseUrl) ->
    @courseName = 'ninghao'
    @hrefList = []


  getRepOP:(url) ->
    options =
      url:url
      headers:
        'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/52.0.2743.116 Safari/537.36',
        'Cookie':''
    return options

  getUrl:(cb) ->
    _this = @
    op = _this.getRepOP(_this.courseUrl)
    request.get op, (err, res, body) ->
      return cb(err) if err

      $ = cheerio.load(body)

      urlList = $("div.header > a")
      if urlList.length is 0
        return cb("没有找到课程列表")

      urlList.each (idx, ele) ->
        url = $(ele).attr('href')
        name = $(ele).text()
        if url.indexOf('video') > 0
          tmp = {
            url:'http://ninghao.net' + url
            name:name
          }
          _this.hrefList.push(tmp)

      cb()


  getSource:(cb) ->
    _this = @
    console.log(_this.hrefList)
    async.each _this.hrefList, (item, callback) ->
      url = item['url']
      name = item['name']
      op = _this.getRepOP(url)
      request.get op, (err, res, body) ->
        return cb(err) if err

        $ = cheerio.load(body)
        source = $("source")
        if source.length == 0
          console.log("Url没有视频", url, name)
          return callback()

        item['video'] = source.attr('src')
        console.log(item)
        callback()

    ,(err) ->
      return console.log(err) if err
      console.log(_this.hrefList)
      cb()


  downInfo:(cb) ->
    _this = @
    async.eachSeries _this.hrefList, (item, callback) ->
      _this.downVideo(item.video, item.name, callback)

    ,(err) ->
      console.log(err)
      cb()


  downVideo:(url, name, cb) ->
    _this = @
    write = fs.createWriteStream(name + ".mp4")
    return cb() if not url
    op = _this.getRepOP(url)
    request.get op

    .on 'response', (res) ->
      console.log "................................."
      console.log "#{name}  #{url}"
      console.log(res.statusCode)
      if res.statusCode is 200
        console.log '连接下载视频成功'

    .on "error", (err) ->
      console.log "#{name}  #{url} down error: #{err}"
      console.log "下载视频出错，准备3s后重试。。。"
      return setTimeout () ->
        self.downVideo(url, name, cb)
      ,3000

    .on 'end', () ->
      console.log "#{name} 下载成功"
      console.log ".................................\n\n\n\n"
      cb()

    .pipe(write)









ng = new NingHao('http://ninghao.net/course/3032')
async.waterfall [
  (cb) ->
    ng.getUrl(cb)

  (cb) ->
    ng.getSource(cb)

  (cb) ->
    ng.downInfo(cb)
]


