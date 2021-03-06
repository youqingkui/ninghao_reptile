request = require("request")
async   = require("async")
fs      = require("fs")
cheerio = require("cheerio")

ninghao = (@cookie, @urlArr) ->

  @href = []
  @info = {}
  @courseName = 'ninghao.net'
  return


ninghao::reqOp = (url) ->
  options =
    url:url
    headers:
      'User-Agent': 'request',
      'Cookie':@cookie

  return options

ninghao::parseUrlArr = () ->
  ### 解析课程链接数组 ###
  self = @
  async.eachSeries self.urlArr, (item, callback) ->
    console.log item
    self.getUrl(item, callback)

  ,(eachErr) ->
    if eachErr
      return console.log "出现错误啦！"

    console.log " ## all do ##"



ninghao::getUrl = (url, cb) ->
  ### 获取课程列表 ###
  self = @
  op = self.reqOp(url)
  request.get op, (err, res, body) ->
    if err
      console.log err
      return console.log "获取课程页面失败，检查网络"

    $ = cheerio.load(body)
    if $(".course-info h1").length is 0
      console.log "没有找到课程名，使用默认课程名 #{self.courseName}"
    else
      self.courseName = $(".course-info h1").text()
      console.log "找到课程名 #{self.courseName}"

    link = $("tr > td a")
    linkLen = link.length
    console.log "查找到得课程列表： #{linkLen}"
    unless linkLen
      console.log "奇怪怎么没有找到课程列表？"
      return false

    link.each (idx, element) ->
      self.href.push($(element).attr("href"))

    unless self.href.length
      console.log "奇怪，应该不会出现这情况吧, @href 为空？"
      return false


    console.log "### 获取课程列表 end ###"
    unless fs.existsSync(self.courseName)
      fs.mkdirSync(self.courseName)
    self.doTask(cb)



ninghao::doTask = (cb) ->
  ### 去获取课程详情页面的下载链接信息 ###
  self = @
  async.eachSeries self.href, (item, callback) ->
    url = 'http://ninghao.net' + item
    self.getDownInfo(url, callback)

  ,(eachErr) ->
    if eachErr
      console.log 'oo)oo(oo'
      return console.log eachErr

    console.log "完成了#{self.courseName}，开始下一批"

    self.href = []
    cb()


ninghao::getDownInfo = (url, cb) ->
  self = @
  op = self.reqOp(url)
  request.get op, (err, res, body) ->
    if err
      console.log err
      console.log "获取下载链接出错，准备3s后重试。。。"
      return setTimeout () ->
        self.getDownInfo(url, cb)

      ,3000


    $ = cheerio.load(body)
    findElent = $("#sidebar section div.box")
#    self.info.url  = findElent.eq(0).find("a").attr("href")
    unless $('script:contains("这不是秘密哦")').length
      return console.log "没有获取到下载的信息，可能是没有登录cookie"
    self.info.url  = $('script:contains("这不是秘密哦")').text().trim().split("\n")[2].split('"')[1]
    self.info.name = findElent.eq(0).find("strong").find("a").text()
    self.info.name = self.info.name.replace(/\//g, 'or')
    if not self.info.url or not self.info.name
      return console.log "没有发现下载的课程名和URL"

    console.log "获取到 #{self.info.name} 以及下载URL #{self.info.url}"

    self.downVideo(cb)


ninghao::downVideo = (cb) ->
  self = @
  op = self.reqOp(self.info.url)
  write = fs.createWriteStream(self.courseName + '/' + self.info.name + ".mp4")

  request.get op

  .on 'response', (res) ->
    console.log "................................."
    console.log "#{self.info.name}  #{self.info.url}"
    console.log(res.statusCode)
    if res.statusCode is 200
#      console.log res
      console.log '连接下载视频成功'

  .on "error", (err) ->
    console.log "#{self.info.name}  #{self.info.url} down error: #{err}"
    console.log "下载视频出错，准备3s后重试。。。"
    return setTimeout () ->
      self.downVideo(cb)

    ,3000

  .on 'end', () ->
    console.log "#{self.info.name} 下载成功"
    console.log ".................................\n\n\n\n"
    cb()

  .pipe(write)




















console.log(process.env.NingHao)
loginCookie = process.env.NingHao
downUrlArr = [
  'http://ninghao.net/course/1584',
  'http://ninghao.net/course/1479',
  'http://ninghao.net/course/1444'
]
down = new ninghao(loginCookie, downUrlArr)
down.parseUrlArr()