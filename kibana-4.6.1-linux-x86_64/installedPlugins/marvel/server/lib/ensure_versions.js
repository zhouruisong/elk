/*
 * Ensure version compatibility with Kibana
 * Marvel 2.2.0 should work with Kibana > v4.4.0
 * https://www.elastic.co/guide/en/marvel/current/installing-marvel.html
 * Semver tester: http://jubianchi.github.io/semver-check/
 */
import _ from 'lodash';
import { satisfies } from 'semver';
import pkg from '../../package.json';

const KBN_VERSION_RANGE = '~4.6.0';
const KBN_VERSION_DISPLAY = '4.6.x';

function cleanVersionString(string) {
  if (string) {
    // get just the number.number.number portion (filter out '-snapshot')
    const matches = string.match(/^\d+\.\d+.\d+/);
    if (matches) {
      // escape() because the string could be rendered in UI
      return _.escape(matches[0]);
    }
  }

  return '';
}

function ensureVersions(plugin) {

  const kibanaVersion = cleanVersionString(_.get(plugin, 'kbnServer.version'));
  const marvelVersion = cleanVersionString(pkg.version);
  const returnData = { kibanaVersion, marvelVersion, kbnVersionDisplay: KBN_VERSION_DISPLAY };

  // version support check can throw a TypeError if kibanaVersion is invalid
  try {
    returnData.isKibanaSupported = satisfies(kibanaVersion, KBN_VERSION_RANGE);
  } catch (e) {
    returnData.isKibanaSupported = false;
  }

  return returnData;

}

export default ensureVersions;
