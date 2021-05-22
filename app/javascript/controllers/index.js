// Load all the controllers within this directory.
// Controller files must be named *_controller.js.

import { Application } from 'stimulus';
import { definitionsFromContext } from 'stimulus/webpack-helpers';

const application = Application.start();
const context = require.context('./', false, /_controller\.js$/);
application.load(definitionsFromContext(context));
