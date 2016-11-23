$(function () {
    $('tr[data-href]').click(function () {
        location.href = $(this).data('href');
    });
});
