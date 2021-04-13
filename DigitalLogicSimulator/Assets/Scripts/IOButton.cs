﻿using UnityEngine;

public class IOButton : MonoBehaviour {
    private IO.state currentState;
  

    private void Update() {
        if(Time.timeScale == 0)return;
        if (gameObject.transform.parent.GetComponent<IO>().IOType == IO.type.IN) {
            if (gameObject.transform.parent.GetComponent<IO>().log == IO.logic.HIGH)
                gameObject.GetComponent<SpriteRenderer>().color = new Color(236f / 255f, 34f / 255f, 56f / 255f, 1f);
            else if (gameObject.transform.parent.GetComponent<IO>().log == IO.logic.LOW)
                gameObject.GetComponent<SpriteRenderer>().color = new Color(82f / 255f, 80f / 255f, 80f / 255f, 1f);
        }
    }

    private void OnMouseOver() {
        currentState = gameObject.transform.parent.GetComponent<IO>().currentState;
        if (Input.GetMouseButtonDown(0) && currentState == IO.state.INSCENE &&
            gameObject.transform.parent.GetComponent<IO>().IOType == IO.type.OUT) {
            //print("clicked");
            gameObject.transform.parent.GetComponent<IO>().noChange = true;
            //print(gameObject.transform.parent.GetComponent<IO>().log);
            if (gameObject.transform.parent.GetComponent<IO>().log == IO.logic.LOW) {
                gameObject.GetComponent<SpriteRenderer>().color = new Color(236f / 255f, 34f / 255f, 56f / 255f, 1f);
                gameObject.transform.parent.GetComponent<IO>().log = IO.logic.HIGH;
            }
            else {
                gameObject.transform.parent.GetComponent<IO>().log = IO.logic.LOW;
                gameObject.GetComponent<SpriteRenderer>().color = new Color(82f / 255f, 80f / 255f, 80f / 255f, 1f);
            }
        }
    }
}