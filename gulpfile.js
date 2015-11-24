// Gulp and gulp extensions
var gulp  = require('gulp');
var debug = require('gulp-debug');

// Load envs from .env files
var dotenv = require('dotenv');
dotenv.load({ silent: true });

// Deploying zipped files
gulp.task('deploy', function() {

  // Select bucket
  var yargs  = require('yargs');
  var bucket = process.env[
    "AWS_BUCKET_" + (yargs.argv.production ? "PROD" : "STAGE")
  ];

  // create a new publisher
  var awspublish = require('gulp-awspublish');
  var publisher  = awspublish.create({
    params: {
      Bucket: bucket,
    },
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_KEY,
    region: 'sa-east-1',
  });

  // define custom headers
  var headers = {
    'Cache-Control': 'max-age=315360000, no-transform, public',
  };

  var replace = require('gulp-replace');

  // Replaces for production from .env
  var src = gulp.src("./start.sh");
  if (! yargs.argv.production) {
    // Replacing azk repository
    src = src.pipe(
      replace(/http:\/\/www\.azk\.io\/install\.sh \| bash/,
              "http://www.azk.io/install.sh | bash -s stage")
    );
  }

  return src
    .pipe(debug())
    // publisher will add Content-Length, Content-Type and headers specified above
    // If not specified it will set x-amz-acl to public-read by default
    .pipe(publisher.publish(headers))
    // create a cache file to speed up consecutive uploads
    .pipe(publisher.cache())
    // print upload updates to console
    .pipe(awspublish.reporter());
});

gulp.task('default', ['deploy']);