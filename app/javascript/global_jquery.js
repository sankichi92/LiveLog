// https://gorails.com/forum/how-to-use-jquery-jqueryui-with-esbuild-discussion

import jquery from 'jquery';
import select2 from 'select2';

window.jQuery = jquery;
window.$ = jquery;
window.select2 = select2();

export default jquery;
