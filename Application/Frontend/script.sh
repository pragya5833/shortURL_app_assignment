#clone the code with url-shortener-landing
npm install
npm run build
aws s3 sync build/ s3://landingpageshorturlhost --delete
#clone the code with frontend
npm install
npm run build
aws s3 sync build/ s3://frontendshorturlhost --delete