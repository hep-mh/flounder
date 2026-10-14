{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load({
  onEntrypointLoaded: async function(engineInitializer) {
    const loading = document.querySelector('#loading');
    loading.classList.add('main_done');
    
    const appRunner = await engineInitializer.initializeEngine();
    
    await appRunner.runApp();
    
    loading.remove();
  }
});