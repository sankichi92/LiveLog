import { application } from '../application';

import DatatableController from './datatable_controller';
application.register('datatable', DatatableController);

import FormPlayableTimesController from './form_playable_times_controller';
application.register('form-playable-times', FormPlayableTimesController);

import FormPlaysController from './form_plays_controller';
application.register('form-plays', FormPlaysController);
