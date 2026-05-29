import { useState, useEffect } from 'react';

/** Même base que `lib/api.js` : le dashboard appelle l’API via le domaine principal. */
const API_PRIMARY = 'https://auxivie.org';
/** Hôte alternatif (même backend en prod si DNS configuré). */
const API_ALT = 'https://api.auxivie.org';

export default function Diagnostic() {
  const [results, setResults] = useState({
    loading: true,
    tests: {},
    systemInfo: {},
  });

  useEffect(() => {
    runDiagnostics();
  }, []);

  const runDiagnostics = async () => {
    const tests = {};
    const systemInfo = {};

    // System info
    systemInfo.userAgent = navigator.userAgent;
    systemInfo.online = navigator.onLine;
    systemInfo.language = navigator.language;
    systemInfo.timezone = new Date().getTimezoneString?.() || new Date().toTimeString();

    // Test 1: Browser is online
    try {
      tests.browserOnline = {
        passed: navigator.onLine,
        message: navigator.onLine ? 'Navigateur connecté à internet ✅' : '❌ Navigateur hors ligne',
      };
    } catch (error) {
      tests.browserOnline = {
        passed: false,
        message: 'Impossible de vérifier la connexion',
      };
    }

    // Test 2: API + CORS (GET réel — les en-têtes CORS ne sont pas toujours lisibles en JS sur une requête OPTIONS)
    try {
      console.log('Testing API + CORS (primary)...');
      const response = await Promise.race([
        fetch(`${API_PRIMARY}/api/health`, {
          method: 'GET',
          mode: 'cors',
          credentials: 'include',
        }),
        new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout')), 8000)),
      ]);
      const corsOk = response.type === 'cors' && response.ok;
      tests.apiReachability = {
        passed: corsOk,
        message: corsOk
          ? `API ${API_PRIMARY}/api — CORS OK (réponse lisible depuis ce site) ✅`
          : response.type === 'opaque'
            ? 'Réponse « opaque » : CORS ou réseau bloque l’accès à l’API.'
            : `HTTP ${response.status} (type: ${response.type})`,
      };
    } catch (error) {
      tests.apiReachability = {
        passed: false,
        message: `API inaccessible : ${error.message}`,
      };
    }

    // Test 3: CORS (même résultat que le test API : on ne se fie pas aux en-têtes lus en JS)
    tests.cors = {
      passed: tests.apiReachability?.passed === true,
      message:
        tests.apiReachability?.passed === true
          ? 'CORS actif pour cette origine (réponse cross-origin exploitable, type « cors ») ✅'
          : tests.apiReachability?.message
            ? `Lié au test API ci-dessus : ${tests.apiReachability.message}`
            : 'Exécutez d’abord le test de joignabilité API.',
    };

    // Test 4: Check SSL/TLS
    try {
      console.log('Testing SSL...');
      await fetch(API_PRIMARY, {
        method: 'HEAD',
        mode: 'cors',
      });
      tests.ssl = {
        passed: true,
        message: 'Certificat TLS (auxivie.org) joignable ✅',
      };
    } catch (error) {
      tests.ssl = {
        passed: false,
        message: `SSL / TLS : ${error.message}`,
      };
    }

    // Test 5: DNS / hôte secondaire (informatif)
    try {
      console.log('Testing alternate API host...');
      const response = await Promise.race([
        fetch(`${API_ALT}/api/health`, {
          method: 'GET',
          mode: 'cors',
          credentials: 'include',
        }),
        new Promise((_, reject) => setTimeout(() => reject(new Error('Timeout')), 8000)),
      ]);
      const ok = response.type === 'cors' && response.ok;
      const primaryOk = tests.apiReachability?.passed === true;
      tests.dns = {
        passed: ok || primaryOk,
        message: ok
          ? `Hôte secondaire ${API_ALT}/api joignable ✅`
          : primaryOk
            ? `Hôte secondaire : optionnel — ${API_PRIMARY} suffit pour le dashboard ✅`
            : `Hôte secondaire indisponible (HTTP ${response.status}, type ${response.type}).`,
      };
    } catch (error) {
      const primaryOk = tests.apiReachability?.passed === true;
      tests.dns = {
        passed: primaryOk,
        message: primaryOk
          ? `Hôte secondaire : erreur (${error.message}) — ignoré car ${API_PRIMARY} répond ✅`
          : `Hôte secondaire non joignable : ${error.message}`,
      };
    }

    // Test 6: Prévol OPTIONS login (domaine principal)
    try {
      console.log('Testing login endpoint OPTIONS (primary)...');
      const response = await fetch(`${API_PRIMARY}/api/auth/login`, {
        method: 'OPTIONS',
        mode: 'cors',
        credentials: 'include',
        headers: {
          'Access-Control-Request-Method': 'POST',
          'Access-Control-Request-Headers': 'Content-Type,Authorization',
        },
      });
      tests.loginEndpointOPTIONS = {
        passed: response.ok || response.status === 204,
        message: `OPTIONS /api/auth/login (${API_PRIMARY}) → ${response.status} ✅`,
      };
    } catch (error) {
      tests.loginEndpointOPTIONS = {
        passed: false,
        message: `OPTIONS login : ${error.message}`,
      };
    }

    // Test 7: POST login (identifiants invalides attendus)
    try {
      console.log('Testing login endpoint POST (primary)...');
      const response = await fetch(`${API_PRIMARY}/api/auth/login`, {
        method: 'POST',
        mode: 'cors',
        credentials: 'include',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ email: 'test@test.com', password: 'test' }),
      });
      tests.loginEndpointPOST = {
        passed: response.status === 401 || response.status === 200 || response.status === 400,
        message: `POST /api/auth/login (${API_PRIMARY}) → ${response.status} ✅`,
      };
    } catch (error) {
      tests.loginEndpointPOST = {
        passed: false,
        message: `POST login : ${error.message}`,
      };
    }

    // Test 8: IP en HTTP — depuis une page HTTPS le navigateur bloque (mixed content) : on ne teste pas, ce n’est pas une erreur prod.
    const pageIsHttps = typeof window !== 'undefined' && window.location.protocol === 'https:';
    if (pageIsHttps) {
      tests.fallbackDirectIP = {
        passed: true,
        message:
          'Non applicable : depuis HTTPS, une requête HTTP vers une IP est bloquée (mixed content). Le dashboard utilise uniquement des URLs HTTPS.',
      };
    } else {
      try {
        console.log('Testing fallback URL (Direct IP:8080)...');
        const response = await fetch('http://178.16.131.24:8080/api/auth/login', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email: 'test@test.com', password: 'test' }),
        });
        tests.fallbackDirectIP = {
          passed: response.status === 401 || response.status === 200 || response.status === 400,
          message: `Fallback IP (HTTP) → ${response.status} ✅`,
        };
      } catch (error) {
        tests.fallbackDirectIP = {
          passed: false,
          message: `Fallback IP : ${error.message}`,
        };
      }
    }

    // Infos navigateur
    tests.browser = {
      passed: true,
      message: `${navigator.userAgent.substring(0, 70)}...`,
    };

    setResults({
      loading: false,
      tests,
      systemInfo,
    });
  };

  const allTestsPassed = Object.values(results.tests).every(t => t.passed);

  return (
    <div style={{ padding: '40px', fontFamily: 'Arial, sans-serif', maxWidth: '900px', margin: '0 auto' }}>
      <h1>🔍 Diagnostic - Aidalya Admin</h1>
      <p>Cette page teste la connectivité entre votre navigateur et le serveur API.</p>

      <div style={{ marginTop: '20px', padding: '15px', backgroundColor: '#f0fdf4', borderRadius: '8px', border: '1px solid #86efac' }}>
        <strong>État du diagnostic:</strong>
        <p style={{ margin: '5px 0' }}>
          Connexion Internet: {results.systemInfo.online ? '✅ En ligne' : '❌ Hors ligne'}
        </p>
        <p style={{ margin: '5px 0' }}>
          Navigateur: {results.systemInfo.userAgent?.substring(0, 50)}...
        </p>
      </div>

      <div style={{ marginTop: '30px' }}>
        <h2>Résultats des tests</h2>
        {results.loading ? (
          <p>Exécution des tests en cours...</p>
        ) : (
          <div>
            {Object.entries(results.tests).map(([testName, result]) => (
              <div
                key={testName}
                style={{
                  padding: '15px',
                  marginBottom: '15px',
                  border: `2px solid ${result.passed ? '#16a34a' : '#dc2626'}`,
                  borderRadius: '8px',
                  backgroundColor: result.passed ? '#f0fdf4' : '#fef2f2',
                }}
              >
                <strong style={{ color: result.passed ? '#166534' : '#991b1b' }}>
                  {testName.replace(/([A-Z])/g, ' $1').trim()}:
                </strong>
                <p style={{ margin: '8px 0 0 0', color: result.passed ? '#166534' : '#991b1b' }}>
                  {result.message}
                </p>
              </div>
            ))}
          </div>
        )}
      </div>

      <div style={{ marginTop: '40px', padding: '20px', backgroundColor: allTestsPassed ? '#f0fdf4' : '#fef2f2', borderRadius: '8px', border: `2px solid ${allTestsPassed ? '#16a34a' : '#dc2626'}` }}>
        <h3>{allTestsPassed ? '✅ Tous les tests réussis!' : '⚠️ Certains tests ont échoué'}</h3>
        
        {allTestsPassed ? (
          <p>
            Votre connexion au serveur API semble fonctionner correctement. Si vous rencontrez toujours des problèmes de login, il peut s'agir d'un problème d'authentification (email/mot de passe incorrect) plutôt qu'un problème de connexion.
          </p>
        ) : (
          <div>
            <p><strong>Important:</strong> Le diagnostic utilise surtout <code>https://auxivie.org/api</code> (comme la page de connexion). Un échec sur <code>api.auxivie.org</code> seul peut être ignoré si le test principal est vert.</p>
            
            <p><strong>Résumé des résultats:</strong></p>
            <ul>
              <li>🔴 « API / CORS » en échec → problème réseau, pare-feu ou configuration CORS sur le serveur</li>
              <li>🟢 « Fallback direct IP » ignoré en HTTPS → comportement normal du navigateur (mixed content)</li>
            </ul>
            
            <p><strong>Les causes courantes:</strong></p>
            <ul>
              <li><strong>Pare-feu/proxy d'entreprise:</strong> Bloque les domaines externes (api.auxivie.org)</li>
              <li><strong>Filtrage DNS:</strong> Le fournisseur Internet bloque la résolution de ce domaine</li>
              <li><strong>Filtrage de contenu:</strong> Votre réseau a des règles strictes sur les domaines</li>
              <li><strong>Antivirus/VPN personnel:</strong> Peut bloquer certaines connexions</li>
            </ul>
            
            <p><strong>Solutions recommandées:</strong></p>
            <ul>
              <li>✅ Si <code>auxivie.org/api</code> est vert, la connexion admin peut fonctionner même si l’hôte secondaire échoue</li>
              <li>Essayez sur un autre réseau (Hotspot mobile, réseau public, VPN)</li>
              <li>Essayez sur un autre navigateur ou appareil</li>
              <li>Contactez votre administrateur réseau si vous êtes sur un réseau d'entreprise</li>
            </ul>
          </div>
        )}
      </div>

      <div style={{ marginTop: '30px', padding: '20px', backgroundColor: '#f9f9f9', borderRadius: '8px', border: '1px solid #e5e7eb' }}>
        <h3>Informations système (à partager si vous demandez de l'aide)</h3>
        <pre style={{ backgroundColor: '#f3f4f6', padding: '10px', borderRadius: '4px', fontSize: '12px', overflow: 'auto' }}>
{JSON.stringify({
  navigator: {
    userAgent: results.systemInfo.userAgent,
    language: results.systemInfo.language,
    onLine: results.systemInfo.online,
  },
  testResults: Object.entries(results.tests).reduce((acc, [key, val]) => {
    acc[key] = val.passed ? 'PASS' : 'FAIL';
    return acc;
  }, {}),
}, null, 2)}
        </pre>
      </div>

      <div style={{ marginTop: '20px', textAlign: 'center' }}>
        <button
          onClick={runDiagnostics}
          style={{
            padding: '10px 20px',
            backgroundColor: '#16a34a',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: 'bold',
          }}
        >
          Re-tester
        </button>
        <button
          onClick={() => window.location.href = '/login'}
          style={{
            padding: '10px 20px',
            marginLeft: '10px',
            backgroundColor: '#0066cc',
            color: 'white',
            border: 'none',
            borderRadius: '6px',
            cursor: 'pointer',
            fontSize: '14px',
            fontWeight: 'bold',
          }}
        >
          Retour à la connexion
        </button>
      </div>
    </div>
  );
}
