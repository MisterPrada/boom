import * as THREE from 'three'
import Model from './Abstracts/Model.js'
import Experience from '../Experience.js'
import Debug from '../Utils/Debug.js'
import State from "../State.js";
import Materials from "../Materials/Materials.js";

import vertexShader from '../Shaders/PhongMaterial/vertex.glsl'

export default class Ground extends Model {
    experience = Experience.getInstance()
    debug = Debug.getInstance()
    state = State.getInstance()
    materials = Materials.getInstance()
    scene = experience.scene
    time = experience.time
    camera = experience.camera.instance
    renderer = experience.renderer.instance
    resources = experience.resources
    container = new THREE.Group();

    u_Progress = 0

    constructor() {
        super()

        this.setModel()
        this.setDebug()
    }

    setModel() {
        this.model = this.resources.items.groundModel
        //this.model.scale.set(0.01, 0.01, 0.01);
        //this.model.rotation.x = Math.PI / 2;

        // set matrix rotation Math.PI / 2;
        this.model.applyMatrix4(new THREE.Matrix4().makeRotationX(- Math.PI / 2));


        this.model.traverse((child) => {
            if (child.isMesh) {
                child.frustumCulled = false
                this.material = child.material
            }
        })

        this.material.onBeforeCompile = (shader) => {
            shader.vertexShader = vertexShader

            this.material.uniforms = shader.uniforms
            this.material.uniforms.u_Progress = new THREE.Uniform(this.u_Progress)
        }


        this.container.add(this.model);
        this.scene.add(this.container);
    }

    resize() {

    }

    setDebug() {
        if ( !this.debug.active ) return

        this.debugFolder = this.debug.panel.addFolder( 'ground' );
        this.debugFolder.add( this, 'u_Progress', 0.0, 1, 0.001 ).onChange( () => {
            this.material.uniforms.u_Progress.value = this.u_Progress
        })


        //this.debug.createDebugTexture( this.resources.items.displacementTexture )
    }

    update( deltaTime ) {
        //this.cube2.rotation.y += deltaTime * 20
        //this.cube.rotation.y += deltaTime * 30
    }

}
