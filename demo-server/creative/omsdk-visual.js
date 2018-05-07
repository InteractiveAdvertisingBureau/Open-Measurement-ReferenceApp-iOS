;(function(omidGlobal) {
  const verificationClient = new omidGlobal.OmidVerificationClient['1.0.0']();

  if (!verificationClient.isSupported()) {
    console.log('Omid was not available for client to call');
    return;
  }

  var setBackgroundColor = function (visibilityPercentage) {
    var color = 'Gray';
    if (visibilityPercentage >= 75) {
      color = 'Green';
    } else if (visibilityPercentage >= 50) {
      color = 'PaleGreen';
    } else if (visibilityPercentage >= 25) {
      color = 'PaleVioletRed';
    } else if (visibilityPercentage < 25) {
      color = 'Red';
    }

    document.getElementById('omsdk-dash').style['backgroundColor'] = color;
  };

  var sessionObserver = function (data) {
    console.log(data.type);
    logEvent(data.type);
  };

  var geometryHandler = function (data) {
    var percentageInView = data.data.adView.percentageInView;

    document.getElementById('omsdk-piv').innerText = (percentageInView + "%");

    setBackgroundColor(percentageInView);
  };

  var eventHandler = function (data) {
    var percentage = 0;
    if (data.data.adView) {
      percentage = data.data.adView.percentageInView || 0;
    }

    logEvent(data.type, percentage);
  };

  var logEvent = function (message, percentageInView) {
    console.log(message);

    var date = new Date();
    var time = date.getHours() + ":" + date.getMinutes() + ":" + date.getSeconds();

    var events = document.getElementById('omsdk-events');
    var br = document.createElement("br");
    var inView = (percentageInView != undefined ? " (in view: " + percentageInView + "%)" : "")
    var text = document.createTextNode(" [" + time + "] " + message + inView);
    events.appendChild(text);
    events.appendChild(br);
  };

  verificationClient.registerSessionObserver(sessionObserver, "omsdk-visual");
  verificationClient.addEventListener('sessionStart', eventHandler);
  verificationClient.addEventListener('sessionFinish', eventHandler);
  verificationClient.addEventListener('sessionError', eventHandler);
  verificationClient.addEventListener('impression', eventHandler);
  verificationClient.addEventListener('geometryChange', eventHandler);
  verificationClient.addEventListener('geometryChange', geometryHandler);
}).call(this, this);