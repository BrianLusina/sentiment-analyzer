import React from 'react';
import {
    render
} from 'react-dom';
import './index.css';
import App from './App';
import registerServiceWorker from './registerServiceWorker';
import MuiThemeProvider from "material-ui/styles/MuiThemeProvider";

render( 
    <MuiThemeProvider >
       <App />
    </MuiThemeProvider>, 
    document.getElementById('root')
);
registerServiceWorker();