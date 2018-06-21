import React, { Component, createRef} from 'react';
import './App.css';
import Polarity from "./components/Polarity";
import TextField from 'material-ui/TextField';
import Button from 'material-ui/Button';
import Paper from 'material-ui/Paper';
// import axios from "axios";

const style = {
    marginLeft: 12,
};

class App extends Component {
  constructor(props, context){
    super(props, context);
    this.state = {
      sentence: "",
      polarity: undefined,
      error: {}
    }

    this.textField = createRef()
  }

  __analyzeSentence = () => {
      const { sentence } = this.state;
      // axios.post("http://webapp:8080/sentiment", {
      //   sentence
      //  }).then(response => {
      //    const { sentence, polarity } = response.data;

      //    this.setState({
      //      sentence, polarity
      //    })
      //  }).catch(error => {
      //    this.setState({error})
      //  })
      fetch('http://webapp:8080/sentiment', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({sentence})
      })
      .then(response => response.json())
      .then(({ sentence, polarity }) => this.setState({ sentence, polarity}));
  }

  onEnterPress = e =>{
    if(e.key === "Enter"){
      this.__analyzeSentence()
    }
  }

  onInputChange = e => {
    this.setState({
      sentence: e.target.value
    })
  }

  render() {
    const { polarity, sentence } = this.state;
    const polarityComponent = polarity !== undefined ? <Polarity sentence={sentence} polarity={polarity}/> : null;

    return (
        <div className="centerize">
            <Paper zDepth={1} className="content">
                <h2>Sentiment Analyser</h2>
                <TextField ref={this.textField} onKeyUp={this.onEnterPress}
                          hintText="Type your sentence." onChange={this.onInputChange}/>
                <Button variant="raised" style={style} onClick={this.__analyzeSentence}>
                  Send
                </Button>
                {polarityComponent}
            </Paper>
        </div>
      );
      
  }
}

export default App;
