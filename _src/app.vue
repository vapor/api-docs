<template>
    <main class="vapor-app">
        <vapor-nav class="vapor-app__nav"/>
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
</style>
