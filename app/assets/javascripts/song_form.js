$(document).on('turbolinks:load', function () {
    $('.select2').select2({theme: 'bootstrap'});

    $('form').on('click', '#add-member', function () {
        var reg = /(song_playings_attributes_|song\[playings_attributes]\[)\d+/gi;
        var mSec = new Date().getTime();
        var fields = $(this).data('fields');
        fields = fields.replace(reg, '$1' + mSec);
        $(fields)
            .appendTo('#playings-fields').hide().slideDown()
            .find('.select2').select2({theme: 'bootstrap'});
    });

    $('#playings-fields').on('click', '.remove-member', function () {
        var prefix = '#' + $(this).data('prefix');
        $(prefix + '__destroy').val('1');
        $(prefix + '_fields').slideUp();
    });
});
