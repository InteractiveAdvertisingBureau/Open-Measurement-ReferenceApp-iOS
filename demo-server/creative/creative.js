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

        document.getElementById('creative').style['backgroundColor'] = color;
    };

    var handleSessionObserverEvent = function (data) {
        if (data.type === 'sessionStart') {
            setAdSessionId(data.adSessionId);
        }
    };

    var handleGeometryChangeEvent = function (data) {
        var percentageInView = data.data.adView.percentageInView;

        document.getElementById('percentageInView').innerText = (percentageInView + "%");

        setBackgroundColor(percentageInView);
    };

    var setAdSessionId = function (message) {
        document.getElementById('omidId').innerText = message;
    };

    verificationClient.registerSessionObserver("vendor1", handleSessionObserverEvent);
    verificationClient.addEventListener('geometryChange', handleGeometryChangeEvent);
}).call(this, this);

