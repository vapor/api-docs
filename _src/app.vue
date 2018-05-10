<template>
    <main class="vapor-app">
        <vapor-nav class="vapor-app__nav"/>

        <iframe src="service/latest/Service/index.html"></iframe>
    </main>
</template>

<script>
    import VaporNav from 'components/nav';

    export default {
        name: 'vaporApp',
        components: {
            [VaporNav.name]: VaporNav
        }
    };
</script>

<style lang="scss">
    .vapor-app {
        width: 100%;
        height: 100%;

        iframe {
            width: 100%;
            height: 100%;
            border: none;
            border-top: 1px solid lightgray;
        }
    }
</style>
