import Vue from 'vue';
import { Dropdown as BootstrapDropdown } from 'bootstrap-vue/src/components';

import App from 'src/app';

import 'bootstrap/dist/css/bootstrap.css'

Vue.use(BootstrapDropdown);

export default new Vue({
    el: '#app',
    render: h => h(App),
    components: {}
});
