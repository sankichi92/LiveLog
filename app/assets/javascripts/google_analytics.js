window.ga = window.ga || function () {
    (ga.q = ga.q || []).push(arguments)
};

ga.l = +new Date;

ga('create', 'UA-56294602-1', 'auto');
ga('require', 'linkid');

$(document).on('turbolinks:load', function (e) {
    ga('set', 'location', e.originalEvent.data.url);
    ga('send', 'pageview');
});
