# Open Measurement Reference App for iOS

A sample iOS application built to show sample usage of OMSDK. This project contains a sample iOS app as well as a demo server which can be used for serving creatives and resources.  The app has examples for html creatives, video creatives, and image creatives.

## Getting Started

Clone the project on to your local machine to get started



### Installing

In order to get the node server up and running you will need to complete the following steps:

Assuming you have already installed Node.js on your machine, cd into the project folder and run the following commands:
```
$ cd demo-server
```

```
$ npm init
```

Hit return to accept the defaults ensuring the following:

```
entry point: (serve.js)
```

Then run the following to install express

```
$ npm install express --save
```

To start the server simply run

```
$ node serve.js
```

## Customization

This project uses a number of sample creatives and resources, however it can be easily customized to test your specific needs.  If you have creatives that you would like to serve locally, simply add those files to  `demo-server/creative`.  This step will allow them to be served by the localhost.  Next, add these paths to the `Constants.ServerResource` enum in the `Utility.swift` file.  This will allow for your newly added creatives to be used by the app.  Finally, replace your newly created links with the sample ones throughout the app for either video, image, or html creatives.  You may also want to replace the verification script in this manner.

If you already have a server running simply add those URLs to `Constants.ServerResource` and use those throughout the app to replace the demo resources.