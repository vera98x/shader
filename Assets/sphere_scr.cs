using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class sphere_scr : MonoBehaviour
{
    public Transform target;
    public Camera cam;

    void Start()
    {
        
    }

    void Update()
    {
        Vector3 screenPos = cam.WorldToScreenPoint(target.position);
        Debug.Log("target is " + screenPos + " pixels from the left");
    }
}
