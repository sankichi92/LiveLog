$(document).on('turbolinks:load', function () {
    $('#alert-donation').on('close.bs.alert', function () {
        document.cookie = "close_alert_donation=1;max-age=2592000"; // 30 days
    })
});
