FROM node:20-alpine
WORKDIR /app
COPY index.html .
EXPOSE 3000
CMD ["node", "-e", "const http=require('http'),fs=require('fs');http.createServer((req,res)=>{res.setHeader('Content-Type','text/html; charset=utf-8');fs.createReadStream('index.html').pipe(res)}).listen(process.env.PORT||3000,'0.0.0.0')"]
