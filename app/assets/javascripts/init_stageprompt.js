$(function () {
  GOVUK.performance.stageprompt.setup(function (journeyStage) {
    _gaq.push(['_trackEvent', journeyStage , 'n/a', undefined, undefined, true]);
  })
});
