const http = require('http');
const fs = require('fs');
const path = require('path');
const crypto = require('crypto');
const querystring = require('querystring');

const PORT = 3000;
const DATA_FILE = path.join(__dirname, 'data.json');
const UPLOAD_DIR = path.join(__dirname, 'public', 'upload');

// ====== 简易数据库 ======
function loadData() {
  try { return JSON.parse(fs.readFileSync(DATA_FILE, 'utf8')); } catch(e) { return { users:[], posts:[], nextUserId:1, nextPostId:1 }; }
}
function saveData(data) { fs.writeFileSync(DATA_FILE, JSON.stringify(data, null, 2), 'utf8'); }

function initData() {
  let data = loadData();
  if (data.users.length === 0) {
    data.users.push({ id:1, username:'test', password:md5('123456'), role:'admin', createdTime:now() });
    data.users.push({ id:2, username:'zhangsan', password:md5('123456'), role:'user', createdTime:now() });
    data.nextUserId = 3;
    data.posts.push({ id:1, title:'校园卡丢失', content:'本人于今天下午在图书馆二楼丢失一张校园卡，卡号为20240001，如有捡到请联系我，非常感谢！', type:'lost', imagePath:'', contact:'QQ: 12345678', userId:1, status:0, createTime:now() });
    data.posts.push({ id:2, title:'捡到钥匙一串', content:'在操场跑道旁捡到一串钥匙，上面有蓝色小熊挂件，请失主联系我认领。', type:'found', imagePath:'', contact:'电话: 13800138000', userId:2, status:0, createTime:now() });
    data.posts.push({ id:3, title:'华为手机丢失', content:'周一上午在教学楼A座302教室丢失一部华为手机，黑色外壳，内含重要资料，恳请捡到者联系。', type:'lost', imagePath:'', contact:'微信: lost_phone_2024', userId:1, status:0, createTime:now() });
    data.nextPostId = 4;
    saveData(data);
  }
  return data;
}

function md5(s) { return crypto.createHash('md5').update(s).digest('hex'); }
function now() { return new Date().toISOString().replace('T',' ').substring(0,19); }

// ====== Session管理 ======
const sessions = {};

function parseCookies(cookieHeader) {
  const cookies = {};
  if (cookieHeader) cookieHeader.split(';').forEach(c => { const [k,v] = c.trim().split('='); cookies[k]=v; });
  return cookies;
}

function getSession(req) {
  const sid = parseCookies(req.headers.cookie).sid;
  return sid && sessions[sid] ? sessions[sid] : null;
}

function setSession(res, data) {
  const sid = crypto.randomBytes(16).toString('hex');
  sessions[sid] = data;
  res.setHeader('Set-Cookie', `sid=${sid}; Path=/; HttpOnly`);
  return sid;
}

// ====== 模板渲染 ======
function render(res, templateName, data) {
  const source = fs.readFileSync(path.join(__dirname, 'views', templateName + '.ejs'), 'utf8');
  // Compile EJS-lite template to a JavaScript function body
  let jsBody = 'var __output = "";\n';
  let cursor = 0;
  source.replace(/<%(=?)\s*(.*?)\s*%>/g, (match, eq, code, offset) => {
    jsBody += '__output += ' + JSON.stringify(source.slice(cursor, offset)) + ';\n';
    if (eq === '=') {
      jsBody += '__output += String(' + code + ' || "");\n';
    } else {
      jsBody += code + '\n';
    }
    cursor = offset + match.length;
  });
  jsBody += '__output += ' + JSON.stringify(source.slice(cursor)) + ';\n';
  jsBody += 'return __output;';

  const keys = Object.keys(data);
  const vals = keys.map(k => data[k]);
  const fn = new Function(...keys, jsBody);
  const html = fn(...vals);

  res.writeHead(200, { 'Content-Type': 'text/html; charset=utf-8' });
  res.end(html);
}

// ====== MIME类型 ======
const MIME = {
  '.html':'text/html','.css':'text/css','.js':'application/javascript',
  '.png':'image/png','.jpg':'image/jpeg','.jpeg':'image/jpeg','.gif':'image/gif','.ico':'image/x-icon'
};

function serveStatic(req, res) {
  let filePath = path.join(__dirname, 'public', req.url);
  const ext = path.extname(filePath).toLowerCase();
  if (fs.existsSync(filePath) && fs.statSync(filePath).isFile()) {
    res.writeHead(200, { 'Content-Type': MIME[ext] || 'application/octet-stream' });
    res.end(fs.readFileSync(filePath));
    return true;
  }
  return false;
}

// ====== 解析 multipart ======
function parseMultipart(req, callback) {
  const chunks = [];
  req.on('data', c => chunks.push(c));
  req.on('end', () => {
    const buffer = Buffer.concat(chunks);
    const contentType = req.headers['content-type'] || '';
    const boundary = '--' + contentType.split('boundary=')[1];
    const parts = buffer.toString('binary').split(boundary);
    const fields = {};
    let fileData = null;
    let fileName = '';

    parts.forEach(part => {
      if (part.indexOf('Content-Disposition') === -1) return;
      const headerEnd = part.indexOf('\r\n\r\n');
      if (headerEnd === -1) return;
      const header = part.substring(0, headerEnd);
      const body = part.substring(headerEnd + 4, part.endsWith('--\r\n') ? part.length - 4 : part.length - 2);

      const nameMatch = header.match(/name="([^"]+)"/);
      const fileMatch = header.match(/filename="([^"]+)"/);
      if (nameMatch) {
        if (fileMatch) {
          fileName = fileMatch[1];
          const bodyBuffer = Buffer.from(body, 'binary');
          fileData = bodyBuffer;
        } else {
          fields[nameMatch[1]] = body.trim();
        }
      }
    });

    callback(fields, fileData, fileName);
  });
}

// ====== 路由处理 ======
function handleRequest(req, res) {
  const url = new URL(req.url, 'http://localhost');
  const pathname = url.pathname;

  // 静态文件
  if (serveStatic(req, res)) return;

  const session = getSession(req);
  const publicPaths = ['/login','/register','/css','/js','/upload'];
  const isPublic = publicPaths.some(p => pathname.startsWith(p)) || pathname === '/';

  // 登录拦截
  if (!isPublic && !session) {
    res.writeHead(302, { Location: '/login' });
    return res.end();
  }

  // ====== 路由 ======
  if (pathname === '/login' && req.method === 'GET') {
    return render(res, 'login', { error:'', success:'', user:session||{} });

  } else if (pathname === '/login' && req.method === 'POST') {
    let body = '';
    req.on('data', c => body += c);
    req.on('end', () => {
      const { username, password } = querystring.parse(body);
      const data = loadData();
      const user = data.users.find(u => u.username === username && u.password === md5(password));
      if (user) {
        setSession(res, { id: user.id, username: user.username, role: user.role });
        res.writeHead(302, { Location: '/' });
        res.end();
      } else {
        render(res, 'login', { error:'用户名或密码错误', success:'', user:{} });
      }
    });
    return;

  } else if (pathname === '/register' && req.method === 'GET') {
    return render(res, 'register', { error:'', user:session||{} });

  } else if (pathname === '/register' && req.method === 'POST') {
    let body = '';
    req.on('data', c => body += c);
    req.on('end', () => {
      const { username, password, confirmPassword } = querystring.parse(body);
      if (!username || !password) return render(res, 'register', { error:'用户名和密码不能为空', user:{} });
      if (password.length < 4) return render(res, 'register', { error:'密码长度不能少于4位', user:{} });
      if (password !== confirmPassword) return render(res, 'register', { error:'两次密码输入不一致', user:{} });
      const data = loadData();
      if (data.users.find(u => u.username === username)) return render(res, 'register', { error:'用户名已存在', user:{} });
      data.users.push({ id: data.nextUserId++, username, password: md5(password), role:'user', createdTime: now() });
      saveData(data);
      render(res, 'login', { error:'', success:'注册成功，请登录', user:{} });
    });
    return;

  } else if (pathname === '/logout') {
    res.writeHead(302, { Location: '/login', 'Set-Cookie': 'sid=; Path=/; Max-Age=0' });
    return res.end();

  } else if (pathname === '/' && req.method === 'GET') {
    const data = loadData();
    const type = url.searchParams.get('type') || '';
    const keyword = url.searchParams.get('keyword') || '';
    const page = Math.max(1, parseInt(url.searchParams.get('page')) || 1);
    const pageSize = 10;

    let posts = data.posts.filter(p => p.status === 0);
    if (type) posts = posts.filter(p => p.type === type);
    if (keyword) posts = posts.filter(p => p.title.includes(keyword) || p.content.includes(keyword));
    posts.sort((a,b) => b.id - a.id);

    const total = posts.length;
    const totalPages = Math.ceil(total / pageSize);
    const list = posts.slice((page-1)*pageSize, page*pageSize).map(p => {
      const u = data.users.find(u => u.id === p.userId);
      return { ...p, username: u ? u.username : '未知' };
    });

    render(res, 'index', { list, page, pageSize, total, totalPages, type, keyword, success:'', user:session||{} });

  } else if (pathname === '/publish' && req.method === 'GET') {
    render(res, 'publish', { user:session||{} });

  } else if (pathname === '/publish' && req.method === 'POST') {
    parseMultipart(req, (fields, fileData, fileName) => {
      const data = loadData();
      let imagePath = '';
      if (fileData) {
        const ext = path.extname(fileName) || '.jpg';
        const fname = Date.now() + '-' + Math.round(Math.random()*1E9) + ext;
        fs.writeFileSync(path.join(UPLOAD_DIR, fname), fileData);
        imagePath = '/upload/' + fname;
      }
      data.posts.push({
        id: data.nextPostId++, title: fields.title, content: fields.content, type: fields.type,
        imagePath, contact: fields.contact, userId: session.id, status: 0, createTime: now()
      });
      saveData(data);
      res.writeHead(302, { Location: '/' });
      res.end();
    });
    return;

  } else if (pathname.startsWith('/detail/')) {
    const id = parseInt(pathname.split('/')[2]);
    const data = loadData();
    const post = data.posts.find(p => p.id === id && p.status === 0);
    if (!post) { res.writeHead(302, { Location: '/' }); return res.end(); }
    const username = (data.users.find(u => u.id === post.userId) || {}).username || '未知';
    render(res, 'detail', { post: { ...post, username }, user:session||{} });

  } else if (pathname.startsWith('/edit/') && req.method === 'GET') {
    const id = parseInt(pathname.split('/')[2]);
    const data = loadData();
    const post = data.posts.find(p => p.id === id && p.userId === session.id && p.status === 0);
    if (!post) { res.writeHead(302, { Location: '/user-center' }); return res.end(); }
    render(res, 'edit', { post, user:session||{} });

  } else if (pathname.startsWith('/edit/') && req.method === 'POST') {
    const id = parseInt(pathname.split('/')[2]);
    parseMultipart(req, (fields, fileData, fileName) => {
      const data = loadData();
      const post = data.posts.find(p => p.id === id && p.userId === session.id);
      if (!post) { res.writeHead(302, { Location: '/user-center' }); return res.end(); }
      post.title = fields.title;
      post.content = fields.content;
      post.type = fields.type;
      post.contact = fields.contact;
      if (fileData) {
        const ext = path.extname(fileName) || '.jpg';
        const fname = Date.now() + '-' + Math.round(Math.random()*1E9) + ext;
        fs.writeFileSync(path.join(UPLOAD_DIR, fname), fileData);
        post.imagePath = '/upload/' + fname;
      }
      saveData(data);
      res.writeHead(302, { Location: '/user-center' });
      res.end();
    });
    return;

  } else if (pathname.startsWith('/delete/')) {
    const id = parseInt(pathname.split('/')[2]);
    const data = loadData();
    const post = data.posts.find(p => p.id === id && p.userId === session.id);
    if (post) post.status = 1;
    saveData(data);
    res.writeHead(302, { Location: '/user-center' });
    res.end();

  } else if (pathname === '/user-center') {
    const data = loadData();
    const page = Math.max(1, parseInt(url.searchParams.get('page')) || 1);
    const pageSize = 10;
    let posts = data.posts.filter(p => p.userId === session.id && p.status === 0);
    posts.sort((a,b) => b.id - a.id);
    const total = posts.length;
    const totalPages = Math.ceil(total / pageSize);
    const list = posts.slice((page-1)*pageSize, page*pageSize).map(p => {
      const u = data.users.find(u => u.id === p.userId);
      return { ...p, username: u ? u.username : '未知' };
    });
    render(res, 'user_center', { list, page, pageSize, total, totalPages, success:'', error:'', user:session||{} });
  } else if (pathname === '/panel' && session && session.role === 'admin') {
    const data = loadData();
    const page = Math.max(1, parseInt(url.searchParams.get('page')) || 1);
    const pageSize = 10;
    let posts = [...data.posts].sort((a,b) => b.id - a.id);
    const total = posts.length;
    const totalPages = Math.ceil(total / pageSize);
    const list = posts.slice((page-1)*pageSize, page*pageSize).map(p => {
      const u = data.users.find(u => u.id === p.userId);
      return { ...p, username: u ? u.username : '未知' };
    });
    render(res, 'panel', { list, page, pageSize, total, totalPages, user:session||{} });

  } else if (pathname.startsWith('/panel/delete/') && session && session.role === 'admin') {
    const id = parseInt(pathname.split('/')[3]);
    const data = loadData();
    const post = data.posts.find(p => p.id === id);
    if (post) post.status = 1;
    saveData(data);
    res.writeHead(302, { Location: '/panel' });
    res.end();


  } else {
    res.writeHead(404);
    res.end('Not Found');
  }
}

// ====== 启动服务器 ======
if (!fs.existsSync(UPLOAD_DIR)) fs.mkdirSync(UPLOAD_DIR, { recursive: true });
initData();

const server = http.createServer(handleRequest);
server.listen(PORT, () => {
  console.log(`校园失物招领系统已启动: http://localhost:${PORT}`);
  console.log('测试账号: test / 123456');
});
