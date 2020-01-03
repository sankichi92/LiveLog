$(document).on('turbolinks:load', function () {
    $('form').on('click', '#add-member', function () {
        var reg = /(song_plays_attributes_|song\[plays_attributes]\[)\d+/gi;
        var mSec = new Date().getTime();
        var fields = $(this).data('fields');
        fields = fields.replace(reg, '$1' + mSec);
        $(fields)
            .appendTo('#plays-fields').hide().slideDown()
            .find('.select2').select2({theme: 'bootstrap4'});
    });

    $('#plays-fields').on('click', '.remove-member', function () {
        var prefix = '#' + $(this).data('prefix');
        $(prefix + '__destroy').val('1');
        $(prefix + '_fields').slideUp();
    });
});
