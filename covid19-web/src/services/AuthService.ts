export default class AuthService {

    isAuthenticated() {
        let authFlag = localStorage.getItem('hpccsystems.covid19.auth.status');
        if (authFlag && authFlag === 'true') {
            return true;
        }
    }

    authenticate(user: string, password: string) {
        localStorage.setItem('hpccsystems.covid19.auth.status', 'true');
        localStorage.setItem('hpccsystems.covid19.auth.password', user);
        localStorage.setItem('hpccsystems.covid19.auth.password', password);
    }


}