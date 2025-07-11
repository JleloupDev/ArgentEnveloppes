// Gestion de l'écran de chargement
window.addEventListener('load', function() {
  // Détecter quand Flutter est initialisé
  const observer = new MutationObserver(function(mutations) {
    if (document.querySelector('flt-glass-pane')) {
      // Flutter est initialisé, masquer l'écran de chargement
      document.body.classList.add('flutter-initialized');
      observer.disconnect();
    }
  });
  
  // Observer le body pour détecter quand Flutter ajoute ses éléments
  observer.observe(document.body, {childList: true, subtree: true});

  // Timeout de secours pour masquer l'écran de chargement après un certain temps
  setTimeout(function() {
    document.body.classList.add('flutter-initialized');
  }, 5000); // 5 secondes maximum
});
