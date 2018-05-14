import React, {Component} from 'react';
import {string, number} from 'prop-types';

class Polarity extends Component {

    propTypes = {
        sentence: string.isRequired,
        polarity: number.isRequired
    };

    render() {
        const { polarity, sentence } = this.props;
        const green = Math.round((polarity + 1) * 128);
        const red = 255 - green;
        const textColor = {
            backgroundColor: 'rgb(' + red + ', ' + green + ', 0)',
            padding: '15px'
        };

        return <div style={textColor}>"{sentence}" has polarity of {polarity} </div>
    }
}

export default Polarity;