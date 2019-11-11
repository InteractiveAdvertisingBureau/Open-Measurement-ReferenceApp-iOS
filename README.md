# Open Measurement Reference App for iOS

## Overview

A sample iOS application in Swift built to showcase OM SDK integration. 

Included are 3 sample integrations:

* Native display ad 
* HTML display ad
* Native video ad

## Getting Started

1. Clone the project on to your local machine to get started
2. Download the latest omsdk-v1.js release from the IAB portal (https://tools.iab.techlab.com/omsdk) and drop it into /OMSDK/Service/
3. Build and run in Simulator
4. Use Charles proxy or Safari Web Inspector to see what events OM SDK is receiving
5. Choose one of the sample implementations from the table
6. Wait for the ad to load
7. Observe network calls to `http://iabtechlab.com:66` (the query string will include URL-encoded JSON object with OM SDK event parameters)

## Clarifications

1. The version of OM SDK framework that is provided in this sample project is for education purposes only and **should not** be used for production integration. To get access to production OM SDK build, please refer to the *"Onboarding Guide for Integration Partners"* that is published on [IAB Tech Lab](https://iabtechlab.com/standards/open-measurement-sdk/) and follow the instructions. 
2. For simplicity, this Demo app does not implement parsing of VAST or any other ad response formats. Asset URLs, verification script URLs and parameters are specified as constants instead. Please refer to [IAB Tech Lab](https://iabtechlab.com/standards/open-measurement-sdk/) for details regarding how verification resources are represented in various ad formats.


## Additional Information

* [Open Measurement SDK on IAB Tech Lab](https://iabtechlab.com/standards/open-measurement-sdk/)
