<template>
    <header class="vapor-nav">
        <section class="vapor-nav__main-section">
            <img src="https://api.vapor.codes/api-docs.png"/>

            <nav class="vapor-nav__nav-container">
                <b-dropdown v-for="module in modules"
                            :key="module.name"
                            :text="module.name"
                            :variant="currentModule.name === module.name ? 'success' : 'secondary'"
                            split
                            @click="selectModule(module.name, 'latest')">
                    <b-dropdown-item v-for="version in module.versions"
                                     :key="version"
                                     @click="selectModule(module.name, version)">{{ version }}</b-dropdown-item>
                </b-dropdown>
            </nav>

            <span class="module-version">{{ moduleVersion }}</span>
        </section>
    </header>
</template>

<script>
    export default {
        name: 'vaporNav',
        data() {
            return {
                modules: [
                    {
                        name: 'bits',
                        versions: ['3.0.0', '3.1.2', 'latest'],
                        packageIconUrl: ''
                    },
                    {
                        name: 'core',
                        versions: ['3.0.0', '3.0.2', '3.0.3', '3.1.0', '3.1.2', '3.1.3', '3.1.4', 'latest'],
                        packageIconUrl: ''
                    },
                    {
                        name: 'service',
                        versions: ['1.0.0', 'latest'],
                        packageIconUrl: ''
                    }
                ],
                currentModule: { }
            }
        },
        computed: {
            moduleVersion() {
                if (this.currentModule.version) {
                    return `(Version: ${this.currentModule.version})`;
                }

                return '';
            }
        },
        methods: {
            selectModule(moduleName, moduleVersion) {
                this.currentModule = { name: moduleName, version: moduleVersion }
            }
        }
    };
</script>

<style lang="scss">
    .vapor-nav {
        padding: 1em .5em;

        .vapor-nav__main-section {
            display: flex;
            align-items: center;

            > img {
                height: 3em;
            }
        }

        .vapor-nav__nav-container {
            flex: 1 auto;
            text-align: center;

            > *:not(:first-child) {
                margin-left: .5em;
            }
        }

        .module-version {
            width: 10%;
            padding-right: 1em;
            text-align: right;
        }
    }
</style>
