import * as THREE from 'three'
import Model from './Abstracts/Model.js'
import Experience from '../Experience.js'
import Debug from '../Utils/Debug.js'
import State from "../State.js";
import Materials from "../Materials/Materials.js";

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

    constructor() {
        super()

        this.setModel()
        this.setDebug()
    }

    setModel() {
        // Создание начального куба
        const geometry = new THREE.BoxGeometry(1, 1, 1);
        const material = new THREE.MeshBasicMaterial({ color: 0x00ff00 });
        const cube = new THREE.Mesh(geometry, material);

        this.container.add(cube);
        this.scene.add(this.container);
    }

    resize() {

    }

    setDebug() {
        if ( !this.debug.active ) return

        //this.debug.createDebugTexture( this.resources.items.displacementTexture )
    }

    update( deltaTime ) {
        //this.cube2.rotation.y += deltaTime * 20
        //this.cube.rotation.y += deltaTime * 30
    }

}
